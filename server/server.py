import falcon
import json
import os
import hashlib

class ServerUtils(object):
    @staticmethod
    def get_file_location(filename):
        dirname = os.path.dirname(__file__)
        relpath = os.path.join(dirname, '../builder/output', filename)
        return os.path.abspath(relpath)

    @staticmethod
    def get_file_dir(filename):
        return os.path.dirname(ServerUtils.get_file_location(filename))

    @staticmethod
    def get_my_rsa_key():
        path_to_key = os.path.join(os.environ['HOME'], '.ssh/id_rsa.pub')
        return open(path_to_key).read().strip()


class DeviceConfigResource(object):
    def md5(self, fname):
        hash_md5 = hashlib.md5()
        with open(fname, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        return hash_md5.hexdigest()

    def get_filedescriptor(self, filename):
        return {
            'url': "http://%s/images/global/%s" % (os.environ['LOCALAPI'], filename),
            'md5sum': self.md5(ServerUtils.get_file_location(filename))
        }

    def on_get(self, req, resp, deviceid):
        resp.status = falcon.HTTP_200
        body = {
            'initfs': self.get_filedescriptor('initramfs.tgz'),
            'rootfs': self.get_filedescriptor('rootfs.sqsh'),
            'bootcode': '',
            'usercode': '',
            'config': {
                'ssh': {
                    'pi': {
                        'authorized_keys': [ ServerUtils.get_my_rsa_key() ]
                    }
                }
            }
        }
        resp.body = json.dumps(body)

class TrackAllResource(object):
    def on_get(self, req, resp):
        resp.status = falcon.HTTP_200
        dirname = os.path.dirname(__file__)
        relpath = os.path.join(dirname, '../builder/output')
        resp.body = "Ok " + os.path.abspath(relpath)

class TrackResource(object):
    def on_get(self, req, resp):
        resp.status = falcon.HTTP_200
        resp.body = "Ok"

app = falcon.API()
app.add_route('/boot/{deviceid}/config', DeviceConfigResource())
app.add_route('/track', TrackAllResource())
app.add_route('/track/{deviceid}', TrackResource())
app.add_static_route('/images/global', ServerUtils.get_file_dir('initramfs.tgz'))