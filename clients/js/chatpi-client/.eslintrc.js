const path = require('path');

module.exports = {
  parser: 'babel-eslint',
  extends: ['airbnb'],
  parserOptions: {
    ecmaVersion: 6,
    sourceType: 'module',
    ecmaFeatures: {
      jsx: true,
    },
  },
  plugins: ['jest'],
  env: {
    jest: true,
  },
  globals: {},
  settings: {
    'import/resolver': {
      node: {
        moduleDirectory: [path.resolve('src'), path.resolve('node_modules')],
      },
    },
  },
  rules: {
    'max-len': [1, 80, 2],
    'import/no-named-as-default': 0,
    'no-param-reassign': ['error', { props: false }],
    'no-mixed-operators': 1,
    'no-underscore-dangle': 0,
    'import/no-unresolved': 2,
    'func-names': 0,
    // temporary since webpack-resolver not working with aliases in webpack2
    'import/no-extraneous-dependencies': 0,
    'class-methods-use-this': 0,
    'array-callback-return': 0,
    'space-before-function-paren': 0,
    //prettier
    'function-paren-newline': 0,
    'arrow-parens': 0,
    'import/prefer-default-export': 0,
    'implicit-arrow-linebreak': 0,
    'object-curly-newline': 0,
    // use prettier for these
    'max-len': 0,
    'function-paren-newline': 0,
    'no-confusing-arrow': 0,
    'generator-star-spacing': 0,
    'operator-linebreak': 0,
  },
};
