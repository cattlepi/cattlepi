require 'sinatra'
require 'json'
require 'digest'

set :bind, ENV['SERVERIP']

def get_filepath(filename)
  File.expand_path("../builder/output/#{filename}")
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
    rootfs: get_filedescriptor('rootfs.sqsh') }.to_json
end

get '/file/:fileid' do
  if ['initramfs.tgz', 'rootfs.sqsh'].include?(params['fileid'])
    send_file(get_filepath(params['fileid']))
  else
    status 404
  end
end
