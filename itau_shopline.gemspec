# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "itau_shopline/version"

Gem::Specification.new do |s|
  s.name        = "itau_shopline"
  s.version     = ItauShopline::VERSION
  s.authors     = ["Bruno Frank Cordeiro"]
  s.email       = ["bfscordeiro@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Integração com Itau Shopline}
  s.description = %q{Gem para integração com Itau Shopline e implementação do itaucripto}


  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
