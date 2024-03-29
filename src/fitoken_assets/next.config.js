/** @type {import('next').NextConfig} */

const DFXWebPackConfig = require("../../dfx.webpack.config");
DFXWebPackConfig.initCanisterIds();

const webpack = require("webpack");

// Make DFX_NETWORK available to Web Browser with default "local" if DFX_NETWORK is undefined
const EnvPlugin = new webpack.EnvironmentPlugin({
  DFX_NETWORK: "local",
});

module.exports = {
  webpack: (config, { buildId, dev, isServer, defaultLoaders, webpack }) => {
    // Plugin
    config.plugins.push(EnvPlugin);

    return config;
  },
  reactStrictMode: true,
  images: {
    loader: "custom",
  },
};
