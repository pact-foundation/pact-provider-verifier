require 'json'

run -> (env) {
  body = {"Host" => env['HTTP_HOST']}.to_json
  [200, {"content-type" => "application/json"}, [body]]
}
