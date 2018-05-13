require 'sinatra'
require 'json'
require 'digest'

def get_filepath(filename)
  File.expand_path("../builder/output/#{filename}")
end

get '/boot/:mac/config' do
  content_type :json
  { msg: 'Hello',
    mac: params['mac'],
    initfs: { id: 'initfs', md5sum: Digest::MD5.file(get_filepath('initramfs.tgz')) },
    rootfs: { id: 'rootfs', md5sum: Digest::MD5.file(get_filepath('rootfs.sqsh')) } }.to_json
end

get '/boot/:mac/:fileid' do
  case params['fileid']
  when 'initfs'
    send_file(get_filepath('initramfs.tgz'))
  when 'rootfs'
    send_file(get_filepath('rootfs.sqsh'))
  else
    status 404
  end
end
