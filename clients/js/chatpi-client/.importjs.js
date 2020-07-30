module.exports = {
  excludes: ["**/test/**", "./build/**"],
  sortImports: false,
  danglingCommas: true,
  useRelativePaths: false,
  namedExports: {
    "@storybook/react-native": ["storiesOf"],
    react: [
      "useState",
      "useEffect",
      "useContext",
      "useReducer",
      "useCallback",
      "useMemo",
      "useRef",
      "useImperativeMethods",
      "useLayoutEffect"
    ]
  },
  aliases: {
    PropTypes: "third-party-libs/prop-types",
    useForm: "third-party-libs/react-hook-form",
    TestRenderer: "third-party-libs/react-test-renderer",
    ShallowRenderer: "third-party-libs/react-test-renderer/shallow"
  },
  moduleNameFormatter({ moduleName, pathToCurrentFile }) {
    if (moduleName.startsWith("src/")) {
      // Add a leading slash to foo imports
      return `${moduleName.split("src/")[1]}`;
    }

    if (moduleName.startsWith("third-party-libs/")) {
      // Add a leading slash to foo imports
      return `${moduleName.split("third-party-libs/")[1]}`;
    }

    // Fall back to the original specifier. It's important that this function
    // always returns a string.
    return moduleName;
  }
};
