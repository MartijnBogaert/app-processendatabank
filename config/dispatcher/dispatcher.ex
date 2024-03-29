  # Run `docker-compose restart dispatcher` after updating
  # this file.

defmodule Dispatcher do
  use Matcher
  define_accept_types [
    html: [ "text/html", "application/xhtml+html" ],
    json: [ "application/json", "application/vnd.api+json" ]
  ]

  @any %{}
  @json %{ accept: %{ json: true } }
  @html %{ accept: %{ html: true } }

  define_layers [ :static, :services, :fall_back, :not_found ]

  match "/bpmn-elements", @json do
    Proxy.forward conn, [], "http://resource/bpmn-elements"
  end

  match "/bpmn-elements/*path", @json do
    Proxy.forward conn, path, "http://resource/"
  end

  match "/bpmn-files/*path", @any do
    Proxy.forward conn, path, "http://bpmn/"
  end

  match "/*_", %{ layer: :not_found } do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end
end
