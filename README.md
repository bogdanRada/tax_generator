tax_generator
=============

[![Gem Version](https://badge.fury.io/rb/tax_generator.svg)](http://badge.fury.io/rb/tax_generator) [![Gem Downloads](https://ruby-gem-downloads-badge.herokuapp.com/tax_generator?type=total)](https://github.com/bogdanRada/tax_generator)

Description
-----------

Simple batch processor that takes 2 xml files as input and generates html files with information from the xml elements.

-	*taxonomy.xml* holds the information about how elements are related to each other.

-	*destinations.xml* holds the actual text content for each element.

Each generated web page has:

-	Element text content.

-	Navigation that allows the user to browse to elements that are higher in the taxonomy

-	Navigation that allows the user to browse to destinations that are lower in the taxonomy

Requirements
------------

1.	[Ruby 1.9.x or Ruby 2.x.x](http://www.ruby-lang.org)
2.	[ActiveSuport >= 4.2.0](https://rubygems.org/gems/activesupport)
3.	[celluloid >= 0.16.0](https://github.com/celluloid/celluloid)
4.	[celluloid-pmap >= 0.2.2](https://github.com/jwo/celluloid-pmap)
5.	[nokogiri >= 1.6.7](https://github.com/sparklemotion/nokogiri)
6.	[slop >= 4.2.1](https://github.com/leejarvis/slop)
7.	[rubytree >= 0.9.6](https://github.com/evolve75/RubyTree)

Compatibility
-------------

Rails >3.0 only. MRI 1.9.x, 2.x

Installation Instructions
-------------------------

Add the following to your Gemfile :

```ruby
  gem "tax_generator"
```

And use it like this in your code:

```ruby
 TaxGenerator::Application.new.run(options)
```

or like this:

```ruby
 processor = TaxGenerator::Processor.new(options)
 processor.work
```

where **options** should be a hash that can contain this keys:

-	input_dir
	-	Represents where the taxonomy and the destinations xml files are located ( Default is './data/input')
-	output_dir
	-	Represents where the newly created html files will be located ( Default is './data/output')
-	taxonomy_file_name
	-	Represents the taxonomy file name ( Default is 'taxonomy.xml')
-	destinations_file_name
	-	Represents the destinations xml file name ( Default is 'destinations.xml')

This can also be run from command line using following command:

```ruby
  gem install tax_generator
  tax_generator -i INPUT_DIR -o OUTPUT_DIR -t TAXONOMY_FILENAME -d DESTINATIONS_FILENAME
```

Available command line options when executing a command
-------------------------------------------------------

-	-i or --input_dir

	-	Represents where the taxonomy and the destinations xml files are located ( Default is './data/input')

-	-o or --output_dir

	-	Represents where the newly created html files will be located ( Default is './data/output')

-	-t or --taxonomy_file_name

	-	Represents the taxonomy file name ( Default is 'taxonomy.xml')

-	-d or --destinations_file_name

	-	Represents the destinations xml file name ( Default is 'destinations.xml')

Known Limitations
-----------------

-	Currently it works only if Celluloid.cores >= 2

Testing
-------

To test, do the following:

1.	cd to the gem root.
2.	bundle install
3.	bundle exec rake

Contributions
-------------

Please log all feedback/issues via [Github Issues](http://github.com/bogdanRada/tax_generator/issues). Thanks.

Contributing to tax_generator
-----------------------------

-	Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
-	Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
-	Fork the project.
-	Start a feature/bugfix branch.
-	Commit and push until you are happy with your contribution.
-	Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
-	Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.
-	You can read more details about contributing in the [Contributing](https://github.com/bogdanRada/tax_generator/blob/master/CONTRIBUTING.md) document

== Copyright

Copyright (c) 2015 bogdanRada. See LICENSE.txt for further details.
