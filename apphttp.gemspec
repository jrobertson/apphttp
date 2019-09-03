Gem::Specification.new do |s|
  s.name = 'apphttp'
  s.version = '0.1.0'
  s.summary = 'Makes it trivial to web enable a Ruby project.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/apphttp.rb']
  s.signing_key = '../privatekeys/apphttp.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/apphttp'
end
