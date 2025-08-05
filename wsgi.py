# Run a test server.
from app import create_app
from werkzeug.wrappers import Response

app = create_app()

# Fix for running under /territoire
from werkzeug.middleware.dispatcher import DispatcherMiddleware
application = DispatcherMiddleware(Response("Not Found", status=404), {
    '/territoire': app
})