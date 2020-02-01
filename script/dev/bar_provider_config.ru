require 'json'

app = ->(env) {
  [201, { "Content-Type" => "application/json" }, [{ "name" => "Thing 1" }.to_json]]
}

run app
