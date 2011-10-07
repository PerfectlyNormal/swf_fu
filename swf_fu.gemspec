# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{atlantia-swf_fu}
  s.version = "1.3.4.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Per Christian B. Viken", "Marc-Andre Lafortune", "Marcus Wyatt", "Rodrigo Benenson"]
  s.date = %q{2011-10-04}
  s.description = %q{swf_fu (pronounced "swif-fu", bonus joke for french speakers) uses SWFObject 2.2 to embed swf objects in HTML and supports all its options.
    SWFObject 2 is such a nice library that Adobe now uses it as the official way to embed swf!
    SWFObject's project can be found at http://code.google.com/p/swfobject

    swf_fu has been tested with rails v3.1.1rc3 and had decent test coverage so <tt>rake test:plugins</tt> should have revealed any incompatibilities.
    Comments and pull requests welcome}
  s.email = %q{perchr@northblue.org}
  s.files = [
     "app/helpers/swf_fu_helper.rb",
     "lib/swf_fu.rb",
     "lib/swf_fu/generator.rb",
     "vendor/assets/javascripts/swfobject.js",
     "vendor/assets/swfs/expressInstall.swf"
  ]
  s.homepage = %q{http://github.com/PerfectlyNormal/swf_fu}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{With the swf_fu gem, rails treats your swf files like any other asset (images, javascripts, etc...).}

  current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
  s.specification_version = 3

  s.add_development_dependency(%q<shoulda>, [">= 2.10.3"])
end

