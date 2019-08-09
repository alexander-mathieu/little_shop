![Little Shop Extensions Screenshot](/little_shop_extensions_screenshot.png?raw=true "Little Shop Extensions Screenshot")

# Little Shop

## About
_Little Shop_ is an extension project, building off a fictitious e-commerce site built by [Turing School of Software & Design](https://turing.io). The project implements a new merchant dashboard feature, as well as migrating addresses from the user table in the database to their own separate address table.

The deployed site can be viewed [here](https://little-shop-final.herokuapp.com).

Go ahead and make a user account, and see what you can do!

## Schema

![Imgur](https://i.imgur.com/kEcAZdw.png)

## Local Installation

### Requirements

 * [Ruby 2.4.1](https://www.ruby-lang.org/en/downloads) - Ruby Version
 * [Rails 5.1.7](https://rubyonrails.org) - Rails Version

### Clone

```
git clone https://github.com/alexander-mathieu/little_shop.git
cd little_shop
bundle install
```

### Database Setup

```
rails db:{create,migrate,seed}
```

### Exploration

 * From the `little_shop` project directory, boot up a server with `rails s`
 * Open your browser, and visit `localhost:3000/`
 * Create a user account if you'd like, and explore the site

## Additional Information

 * The full project specs can be viewed [here](https://github.com/turingschool-projects/little_shop_v2/blob/master/solo-project-extensions.md)
 * The test suite can be run with `bundle exec rspec`
 * Happy shopping!
