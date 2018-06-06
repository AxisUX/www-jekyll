module.exports = {
  // webpack folder’s entry js — excluded from jekll’s build process.
  entry: "./webpack/entry.js",
  output: {
    path: "/Users/davidmidlo/Dropbox/projects/AxisUX-WWW/www-jekyll/assets/JavaScripts/",
    filename: "bundle.js"
  },
  module: {
  rules: [
    {
      test: /\.jsx?$/,
      exclude: /(node_modules)/,
      loader: "babel-loader",
      query: {
        plugins: ['transform-runtime'],
        presets: ['env', 'stage-0', 'react']
      }
    }
    ]
  }
};