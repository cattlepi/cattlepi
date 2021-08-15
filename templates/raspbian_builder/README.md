# The CattlePi CI
First: this is experimental. It is used to run the CI builds for https://github.com/cattlepi/cattlepi but it's still in testing and there will be bugs. After all bugs are ironed out, the plan is to package this into a CattlePi recipe that can be used and reused acrossed the board. 

## The CI system
It should go without mention that a CI system is a good idea and we want to autotically validate that both changes to the core Cattle PI software and to the recipes should automatically be validated.

## The Setup
Currently we have 4 Raspberry Pi model 3B+ used to run the CI system. 
3 of them are used as build workers and one of them is used as build control. 

The workflow is: git commit -> github hook -> SQS -> build control picks up the request from SQS and schedules it on a worker  
On the worker: the build updates github via API to indicate request picked -> build is performed -> build artifacts are uploaded to s3 -> build updates github via API to indicate the build request status. 

## Configuration and notes
We use 2 CattlePi API accounts. One is for the workers (all of them) and the other is for the build control.

### Workers config and notes
Config is:
```json
{
  "bootcode": "",
  "config": {
    "autoupdate": true,
    "sdlayout": "bGFiZWw6IGRvcwpkZXZpY2U6IC9kZXYvbW1jYmxrMAp1bml0OiBzZWN0b3JzCgovZGV2L21tY2JsazBwMSA6IHN0YXJ0PSAgICAgICAgMjA0OCwgc2l6ZT0gICAgIDgxOTIwMDAsIHR5cGU9YgovZGV2L21tY2JsazBwMiA6IHN0YXJ0PSAgICAgODE5NDA0OCwgc2l6ZT0gICAgMTg0MzIwMDAsIHR5cGU9ODMK",
    "ssh": {
      "pi": {
        "authorized_keys": [
          "<<first authorized rsa key>>",
          "<<seconde authorized rsa key>>"
        ]
      }
    },
    "standalone": {
      "raspbian_location": "http://192.168.1.87/2018-06-27-raspbian-stretch-lite.zip"
    }
  },
  "initfs": {
    "md5sum": "1bc253db8b243c84f2c41b2485d77021",
    "url": "https://api.cattlepi.com/images/global/raspbian-stock/2018-06-29/v9/initramfs.tgz"
  },
  "rootfs": {
    "md5sum": "82cf5bda1b2fa2da252ab41d3b28b8d7",
    "url": "https://api.cattlepi.com/images/global/raspbian-stock/2018-06-29/v9/rootfs.sqsh"
  },
  "usercode": ""
}
```

The config.sdlayout is:
```bash
label: dos
device: /dev/mmcblk0
unit: sectors

/dev/mmcblk0p1 : start=        2048, size=     8192000, type=b
/dev/mmcblk0p2 : start=     8194048, size=    18432000, type=83
```

192.168.1.87 is the ip of the buildcontrol (we do this in order to prevent a download from the internet every time we reset the worker state)

The workers run the **raspian_stock** recipe. This means that they will get a stock install via the proper recipe. See: https://cattlepi.com/2018/10/11/raspbian-stock-image.html

Keep in mind that buildcontrol will update this config to set the correct pointers for raspbian_location and for the ssh key that the build process uses.

### BuildControl config and notes
Config is:
```json
{
  "bootcode": "",
  "config": {
    "autoupdate": true,
    "buildcontrol": {
      "aws_ak": "<<aws access key>>",
      "aws_s3_bucket": "<<s3 bucket to use for log uploads>>",
      "aws_s3_path": "<<path to s3 bucket>>",
      "aws_sk": "<<aws secret key>>",
      "aws_sqs_queue": "<<aws sqs queue url>>",
      "build_machines": [
        "<<build machine 1 ip>>",
        "<<build machine 2 ip>>",
        "<<build machine 3 ip>>"
      ],
      "builders_api_key": "<<api token of the build_machines(the workers)>>",
      "gh_token": "<<github token>>",
      "gh_user": "<<github user>>",
      "ssh_id_rsa": "<<private key of build control pi>>",
      "ssh_id_rsa_pub": "<<public key of build control pi>>"
    },
    "sdlayout": "bGFiZWw6IGRvcwpkZXZpY2U6IC9kZXYvbW1jYmxrMAp1bml0OiBzZWN0b3JzCgovZGV2L21tY2JsazBwMSA6IHN0YXJ0PSAgICAgICAgMjA0OCwgc2l6ZT0gICAgIDgxOTIwMDAsIHR5cGU9YgovZGV2L21tY2JsazBwMiA6IHN0YXJ0PSAgICAgODE5NDA0OCwgc2l6ZT0gICAgMTg0MzIwMDAsIHR5cGU9ODMK",
    "ssh": {
      "pi": {
        "authorized_keys": [
          "<<authorized ssh key>>"
        ]
      }
    }
  },
  "initfs": {
    "md5sum": "63523e54a3f49918ac3a9a790154e76f",
    "url": "https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v8/initramfs.tgz"
  },
  "rootfs": {
    "md5sum": "5c0318793df00f36244d7ee888f809e7",
    "url": "https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v8/rootfs.sqsh"
  },
  "usercode": "Y3VybCAtc1NMIGh0dHBzOi8vcmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbS9jYXR0bGVwaS9jYXR0bGVwaS1zY3JhdGNoLzIwZGJiOWVlODI0MDAyMzgzMjY2ZGJmYzJlYjZiOWY5NDEzZWYzMGQvYnVpbGRvbnBpL29yaWdpbl9kZXBsb3kuc2ggfCBiYXNoCg=="
}
```

The config.sdlayout is:
```bash
label: dos
device: /dev/mmcblk0
unit: sectors

/dev/mmcblk0p1 : start=        2048, size=     8192000, type=b
/dev/mmcblk0p2 : start=     8194048, size=    18432000, type=83
```

The usercode that run on buildcontrol bootstrap is:
```bash
curl -sSL https://raw.githubusercontent.com/cattlepi/cattlepi-scratch/20dbb9ee824002383266dbfc2eb6b9f9413ef30d/buildonpi/origin_deploy.sh | bash
```

More on the usercode feature here: https://cattlepi.com/2018/08/21/pihole-and-usercode.html

Build control runs the **raspbian_cattlepi** image.

Bootstrap flow is:

 * origin_deploy.sh runs and it:
    * clones the cattlepi-scratch repo
    * runs setup.sh which
      * run the configuration autoupdate 
      * runs through setup_*.sh scripts
        * setup_01part.sh - sets up the sd card partition that build control is going to use on the sd card. We need this because of the big size the images
        * setup_02configs.sh - reads various configs from cattlepi config and exports them as env variables 
        * setup_03install.sh - apt-update + pull down and cache the raspbian image + install nginx to serve the image + install the tooling needed by cattlepi
        * setup_04genaws.sh - sets up aws configuration based on cattlepi config
        * setup_05genssh.sh - setup ssh key + update workers api config 
        * setup_06builders.sh - sets up the local state that will be used to track the builders
        * setup_07perms.sh - moves all of the build control code to its final location
    * runs install_monitor.sh
      * installs a cron job that will run the workflow monitor every minute.

The Workflow_Monitor (workflow_monitor.sh) is:

  * triggered by the cron job. 
  * the only job that is does is check that the build control workflow process is up and running. 
  * if it's not it's starting. So short of starting the workflow the first time, the cron+workflow_monitor act as a nanny that ensure that the workflow is up and running

The Workflow (workflow.sh), in an endless loop:

  * verifies worker state and updates the state on disk (builder_monitor.sh)
    * each worker has a basic state machine. 
    * workers can be in the following states: **unknown, rebuild, ready, building**
    * workers will be placed into **building** when the are actually running a job
    * workers that are not responsive will be placed in the unknown state. If they become responsive they must go through a rebuild
    * workers that finish a build will automatically be placed in rebuild (need to be brough back to stock state) to ensure build consistency (nothing that happened during the recipe build matters as we are starting with a clean slate every time) - builder_monitor WILL NOT touch workers in building (the actual build process will timeout if the builder does not come out of this state within the configured timeout)
  * pull messages from SQS if any (dequeue_work.sh)
    * dequeue message and stage it to be scheduled
    * only one message can be staged at a time (no point in dequeueing stuff if we don't have workers available)
  * schedules work that was requested on a worker if any is available (schedule_work.sh)
    * goes through the builders (looking at their state) and tries to find one in ready **state**
    * if a builder is found it is transitioned to **building** and the state is updated to bind the job that is currently awaiting scheduling with the worker. After the bind, the job is no longer waiting for scheduling.
    * if in the process of scheduling jobs, the request is deemed to be invalid, the message will be acked (ie deleted) from the SQS queue without dispatching it to any worker
  * starts (or restarts in case of crash) the jobs that were scheduled on the workers (run_builders.sh)
    * goes through all the builders 
    * if a builder is in **building** state it will launch a builder process (builder.sh) that actually does the build. 
      * if the process is not there or it has crashed it will restart it
      * if the process is taking a long time (currently JOBTIMEOUT=2700 seconds) it will kill the build process and place the builder in an unknown state.

  The run_builders.sh is to builder processes what the workflow_monitor is to the workflow (with the difference that there is only one workflow process, but there can be multiple builder processes)

The Builder Process (builder.sh):

  * targets one of the Worker Pis 
  * targets one job (request that was made through github webhook -> sqs)
  * while running it:
    * update the GH API to indicate it has started (pending state)
    * uploads initial artifacts to S#
    * checks out the code at the git commit id specified in the request
    * runs the actual build (make raspbian_cattlepi) - this is the step that you would actually do on your dev machine
    * when the process finished it: updates GH API to indicate state (success or failure), uploads build artifacts to S3, acks the message in the SQS queue (ie delete it), cleans the builder state dir + resets the builder to rebuild state.

If this whole insanity is not enough: 

  * the build control code is written in bash - at some point it's worth pondering if we should rewrite this is a "proper language"(TM)
  * it leverages cattlepi + aws cli + curl + jq to get this done in the most straightforward way
  * building the reciped is a good start, but each recipe should come with a battery of tests, and the worker should be configured and rebooted with the recipe just built and the test battery should run against the worker. This is on the roadmap 
  * there is a small chunk of code that runs when the github hook is dispatched and it's not visible here. For all intents and purposes, the interface for build control in the SQS queue (and the SQS queue more or less gets the message github pushes in the body - no munging done, although the code does check that the message comes from GH and does some filtering (ie some messages will not be delivered))
  * the CI raspberry pi "rack" is on its own isolated network. 