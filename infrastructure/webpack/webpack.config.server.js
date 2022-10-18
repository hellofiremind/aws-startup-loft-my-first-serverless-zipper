const path = require('path')
const _ = require('lodash')
const slsw = require('serverless-webpack')
const webpack = require('webpack')
const WebpackNodeExternals = require('webpack-node-externals')
const GeneratePackageJsonWebpackPlugin = require('generate-package-json-webpack-plugin')

const CWD = process.cwd()
const BUILD = path.resolve(CWD, 'build/server')
const SRC = path.resolve(CWD, 'src')
const SERVER_SRC = path.resolve(SRC, 'server')
const PRODUCTION = process.env.NODE_ENV === 'production'
const DEVELOPMENT = 'development'

const plugins = [
  new webpack.NoEmitOnErrorsPlugin(),
  new webpack.EnvironmentPlugin({
    BUILD_STAGE: DEVELOPMENT,
    PRODUCTION,
    SERVICE: slsw.lib.serverless.service.service
  }),
  new GeneratePackageJsonWebpackPlugin()
]

module.exports = {
  context: CWD,
  devtool: 'source-map',
  entry: _.mapValues(slsw.lib.entries, (entry) => ['core-js/stable', 'regenerator-runtime/runtime', entry]),
  externals: [WebpackNodeExternals({
    allowlist: [/\.yml/]
  })],
  mode: PRODUCTION ? 'production' : 'development',
  module: {
    rules: [{
      test: /\.html$/,
      use: ['html-loader']
    }, {
      include: [
        SRC,
        /@hellofiremind/
      ],
      test: /\.js$/,
      use: ['babel-loader']
    }, {
      test: /\.yml$/,
      use: ['json-loader', 'yaml-loader']
    }, {
      test: /\.sql$/,
      use: ['raw-loader']
    }, {
      test: /\.crt$/,
      use: ['raw-loader']
    }, {
      test: /\.pem$/,
      use: ['raw-loader']
    }]
  },
  output: {
    filename: '[name].js',
    libraryTarget: 'umd',
    path: BUILD
  },
  plugins,
  resolve: {
    alias: {
      base_config: path.resolve(CWD, 'config'),
      common: `${SRC}/common`,
      config: `${SERVER_SRC}/config`,
      constant: `${SERVER_SRC}/constant`,
      handlers: `${SERVER_SRC}/handlers`,
      helper: `${SERVER_SRC}/helper`,
      infrastructure: `${CWD}/infrastructure`,
      middleware: `${SERVER_SRC}/middleware`,
      route: `${SERVER_SRC}/route`,
      server: SERVER_SRC,
      service: `${SERVER_SRC}/service`,
      src: SRC
    }
  },
  target: 'node'
}
