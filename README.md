# Epiphany Proclamation Chant (Czech) Generator

Ruby script generating notation for the Epiphany Proclamation chant. Fully automated, using

* [calendarium-romanum](https://github.com/igneus/calendarium-romanum) for calendar computation
* [gly](https://github.com/igneus/gly)
  and [gregorio](https://gregorio-project.github.io) for music engraving

## Usage

* Clone the repository.
* `$ bundle install` to install dependencies.
* `$ bundle exec ruby generate.rb` to generate chant score for the default year range
  (or `$ bundle exec ruby generate.rb 2020 2100` to generate for a custom range - e.g. the rest
  of the century)
* `generate.rb` prints to standard output. If it runs successfully, save the output to a file:
  `$ bundle exec ruby generate.rb > epiphany_proclamation.gly`

In order to transform the gly file to a pdf document, you will need LaTeX and gregorio
(included in current TeXLive). Once these are installed,
run `$ bundle exec gly preview epiphany_proclamation.gly`
It will produce file `epiphany_proclamation.pdf`.

## License

GNU/GPL 3.0 or later
