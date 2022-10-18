const presets = [
  [
    '@babel/preset-env',
    {
      corejs: '3',
      targets: {
        node: 'current'
      },
      useBuiltIns: 'entry'
    }
  ]
]

const plugins = [
  '@babel/plugin-syntax-object-rest-spread',
  '@babel/plugin-proposal-export-default-from',
  '@babel/plugin-syntax-dynamic-import',
  [
    '@babel/plugin-proposal-decorators',
    {
      legacy: true
    }
  ],
  '@babel/plugin-proposal-class-properties'
]

module.exports = (api) => {
  api.cache(true)

  return {
    plugins,
    presets
  }
}
