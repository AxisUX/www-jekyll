# Project Setup Steps
## Jekyll - Webpack - React - Macports - nvm - npm

- Update NVM
    + `cd ~/`
    + `git clone https://github.com/creationix/nvm.git .nvm`
    + `cd ~/.nvm`
    + Check for the latest NVM version [NVM Releases](https://github.com/creationix/nvm/releases)
        * `git checkout v0.33.11`
    + Source the new version from the shell
        * `. nvm.sh`
- Update Node
    + `nvm ls-remote`
    + `nvm install v10.1.0`
    + `nvm use v10.1.0`   
- Update Macports
    + `sudo port -d selfupdate`
    + `sudo port -d upgrade outdated`
- Install Ruby Version Manager
    + `sudo port -d install rvm` 
- Update Ruby
    + Check for latest Ruby [Ruby Releases](https://www.ruby-lang.org/en/downloads/releases/)
    + `rvm install 2.5.1`
    + Install Bundler
        * `sudo gem install bundler` 
    + Create a Gemfile in the project directory
        * `touch Gemfile` 
        * Add github pages gem to gemfile
            ```Ruby
            source 'https://rubygems.org'
            gem 'github-pages', group: :jekyll_plugins
            ``` 
- Install WebPack
    + `sudo npm install webpack -g`
- Install Jekyll
    + `sudo gem install jekyll -g`
    + 'bundle add jekyll'
    + `bundle install`
- Navigate to Project Directory
    + Setup Project Versions
        * Create a direnv directive file
            - `touch .envrc`
            - Add the version of ruby to `.envrc`
                ```shell
                rvm use 2.5.1
                layout Ruby
                ```
        * Setup Node version file
            - Make sure node version is set to updated version, `nvm use v10.1.0`
            - `node -v > .nvmrc`
    + Initialize NPM for the project
        * `npm init`
    + Create `webpack/` directory with an `entry.js` file
        * `mkdir webpack && touch ./webpack/entry.js`
    + Build Jekyll Site
        * 'bundle exec jekyll new ./Axis-User-Experience'
        * Move the contents of `./Axis-User-Experience` to the project's root directory.
            - `mv ./Axis-User-Experience/* ./`
        * In the new `Gemfile`, comment out the line `# gem "jekyll", "~> 3.7.3"` and uncomment `gem "github-pages", group: :jekyll_plugins`
        * `bundle exec jekyll serve`
- Install Babel
    + `npm install webpack --save-dev`
    + `npm install react --save-dev`
    + `npm install react-addons-update --save-dev`
    + `npm install react-dom --save-dev`
    + `npm install babel-core babel-loader --save-dev`
    + `npm install babel-preset-env --save-dev`
    + `npm install babel-preset-react --save-dev`
    + `npm install babel-preset-stage-0 --save-dev`
    + `npm install babel-polyfill --save`
    + `npm install babel-runtime --save`
    + `npm install babel-plugin-transform-runtime --save-dev`



    ### References
    - [Minima Theme](https://github.com/jekyll/minima)
    - [Jekyll Theme Docs](https://jekyllrb.com/docs/themes/)
    - [Alli Zadrozny's "Using Webpack and React with Jekyll"](https://medium.com/@allizadrozny/using-webpack-and-react-with-jekyll-cfe137f8a2cc)
    - [Jekyll::Compose](https://github.com/jekyll/jekyll-compose/blob/master/README.md)

    ### ToDO
    - [Categories](https://blog.webjeda.com/jekyll-categories/)
    - [Testing](https://dev.to/phansch/testing-your-jekyll-website-with-htmlproofer-c6i)
    - [Tested Jekyll](https://gist.github.com/deanmarano/aeae5cd2d357fec1b06e30ead397d4e3)
    - [Testing Snippets](https://www.rubypigeon.com/posts/testing-example-code-in-your-jekyll-posts/)
    - [Testing with HTMLProofer](http://sven-amann.de/blog/2017/01/test-jekyll-builds/)
