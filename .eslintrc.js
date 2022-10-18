module.exports = {
  env: {
    browser: true,
    es6: true,
    node: true
  },
  extends: [
    'standard'
  ],
  parser: '@babel/eslint-parser',
  parserOptions: {
    ecmaFeatures: {
      jsx: true
    },
    ecmaVersion: 6,
    sourceType: 'module'
  },
  plugins: [
    'json',
    'import'
  ],
  rules: {
    'brace-style': ['ERROR', '1tbs'],
    complexity: ['ERROR', {
      max: 4
    }],
    curly: ['ERROR', 'all'],
    'global-require': 'WARN',
    'handle-callback-err': 'ERROR',
    'import/no-unresolved': 'OFF', // This doesn't play very nicely with Webpack at the moment.
    'import/order': ['WARN', {
      'newlines-between': 'never'
    }],
    indent: ['ERROR', 2, { // eslint-disable-line no-magic-numbers
      SwitchCase: 1,
      ignoredNodes: ['ConditionalExpression']
    }],
    'jsx-quotes': ['ERROR', 'prefer-single'],
    'max-depth': ['ERROR', {
      max: 3
    }],
    'max-lines-per-function': ['ERROR', {
      max: 35,
      skipBlankLines: true
    }],
    'max-nested-callbacks': ['ERROR', {
      max: 3
    }],
    'max-params': ['ERROR', {
      max: 5
    }],
    'no-async-promise-executor': 'ERROR',
    'no-console': [process.env.BUILD_STAGE === 'production' ? 'ERROR' : 'WARN', { allow: ['warn', 'error'] }],
    'no-magic-numbers': ['ERROR', {
      ignoreArrayIndexes: true
    }],
    'no-new-require': 'ERROR',
    'no-path-concat': 'ERROR',
    'no-restricted-modules': ['ERROR', 'banned-module'],
    'no-sync': ['ERROR', { allowAtRootLevel: true }],
    'no-unneeded-ternary': 'ERROR',
    'prefer-object-spread': 'ERROR',
    'require-await': 'ERROR',
    'sort-keys': 'ERROR',
    'sort-vars': 'ERROR',
    'vars-on-top': 'ERROR'
  },
  settings: {
    'import/resolver': 'webpack'
  }
}
