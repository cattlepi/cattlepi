require 'sinatra'
require 'json'
require 'digest'

set :bind, ENV['SERVERIP']

def get_filepath(filename)
  File.expand_path("../builder/output/#{filename}")
end

def bootcode_none
  ''
end

def bootcode_simple
  # to see the script (echo booting + sleep + echo continue) issue:
  #   echo IyEvYmluL3NoCmVjaG8gImJvb3RpbmciCnNsZWVwIDUKZWNobyAiY29udGludWUgYm9vdGluZyIK | base64 -d
  'IyEvYmluL3NoCmVjaG8gImJvb3RpbmciCnNsZWVwIDUKZWNobyAiY29udGludWUgYm9vdGluZyIK'
end

def usercode_none
  ''
end

def usercode_reboot_in_30
  # same as bootcode_simple
  'IyEvYmluL3NoCnNsZWVwIDMwCi9zYmluL3NodXRkb3duIC1yIG5vdwo='
end

def get_filedescriptor(filename)
  {
    url: File.join("http://#{ENV['SERVERIP']}:4567/file/#{filename}"),
    md5sum: Digest::MD5.file(get_filepath(filename))
  }
end

get '/boot/:mac/config' do
  content_type :json
  { msg: 'Hello',
    mac: params['mac'],
    initfs: get_filedescriptor('initramfs.tgz'),
    rootfs: get_filedescriptor('rootfs.sqsh'),
    bootcode: bootcode_simple,
    usercode: usercode_none }.to_json
end

get '/file/:fileid' do
  if ['initramfs.tgz', 'rootfs.sqsh'].include?(params['fileid'])
    send_file(get_filepath(params['fileid']))
  else
    status 404
  end
end
