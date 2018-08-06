import falcon

class DeviceConfigResource(object):
    def on_get(self, req, resp, deviceid):
        resp.status = falcon.HTTP_200
        resp.body = "Ok"

class ImagesResource(object):
    def on_get(self, req, resp):
        resp.status = falcon.HTTP_200
        resp.body = "Ok"

class TrackAllResource(object):
    def on_get(self, req, resp):
        resp.status = falcon.HTTP_200
        resp.body = "Ok"

class TrackResource(object):
    def on_get(self, req, resp):
        resp.status = falcon.HTTP_200
        resp.body = "Ok"

app = falcon.API()
app.add_route('/boot/{deviceid}/config', DeviceConfigResource())
app.add_route('/images/{space}/{filename}',ImagesResource())
app.add_route('/track', TrackAllResource())
app.add_route('/track/{deviceid}', TrackResource())