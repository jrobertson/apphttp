Gem::Specification.new do |s|
  s.name = 'apphttp'
  s.version = '0.2.0'
  s.summary = 'Makes it trivial to web enable a Ruby project.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/apphttp.rb']
  s.add_runtime_dependency('kramdown', '~> 2.3', '>=2.3.0')    
  s.signing_key = '../privatekeys/apphttp.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/apphttp'
end
