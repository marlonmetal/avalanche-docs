// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const lightCodeTheme = require('prism-react-renderer/themes/github');
const darkCodeTheme = require('prism-react-renderer/themes/dracula');

/** @type {import('@docusaurus/types').Config} */
const config = {
  i18n: {
    defaultLocale: "en",
    locales: ["en"],
  },

  title: 'Metal Docs',
  tagline: 'Documentation and Tutorials for Metal',
  url: 'https://docs.metalblockchain.org',
  baseUrl: '/',
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/favicon.png',
  organizationName: 'MetalBlockchain', // Usually your GitHub org/user name.
  projectName: 'metal-docs', // Usually your repo name.
  trailingSlash: false,

  scripts: [],

  presets: [
    [
      '@docusaurus/preset-classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          routeBasePath: '/',
          // Please change this to your repo.
          editUrl: 'https://github.com/MetalBlockchain/metal-docs/edit/master/',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      image: 'img/Metal-OG-Image.png?force-reload-1',
      metadata: [
        {name: 'twitter:card', content: 'summary_large_image'},
        {name: 'twitter:description', content: 'Metal is a new blockchain initiative built to power the new era of finance.'},
        {name: 'twitter:title', content:'Developer Documentation and Tutorials for Metal'},
        {name: 'keywords', content: 'Developer Documentation and Tutorials for Metal'}
      ],
      navbar: {
        title: '',
        logo: {
          alt: 'Metal Logo',
          src: 'img/logo.svg',
        },
        items: [
          {
            type: 'docSidebar',
            position: 'left',
            sidebarId: 'overview',
            label: 'Overview',
          },
          // {
          //   type: 'docSidebar',
          //   position: 'left',
          //   sidebarId: 'quickStart',
          //   label: 'Quick Start',
          // },     
          /* {
            type: 'docSidebar',
            position: 'left',
            sidebarId: 'dapps',
            label: 'DApps',
          },  

          {
            type: 'docSidebar',
            position: 'left',
            sidebarId: 'subnets',
            label: 'Subnets',
          },  */
          {
            type: 'docSidebar',
            position: 'left',
            sidebarId: 'apis',
            label: 'APIs',
          }, 
          {
            type: 'docSidebar',
            position: 'left',
            sidebarId: 'nodes',
            label: 'Nodes',
          }, 
          /* {
            type: 'docSidebar',
            position: 'left',
            sidebarId: 'specs',
            label: 'Specs',
          },  */
         /*  {
            type: 'docSidebar',
            position: 'left',
            sidebarId: 'community',
            label: 'Community',
          },  */
          {
            type: 'localeDropdown',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Community',
            items: [
              {
                label: 'Twitter',
                href: 'https://twitter.com/metalpaysme',
              },
              {
                label: 'Telegram',
                href: 'https://t.me/metalpaysme',
              }
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'GitHub',
                href: 'https://github.com/MetalBlockchain',
              }
            ],
          },
          {
            
          }
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Metallicus, Inc.`,
      },
      prism: {
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
      }
    }),
};

module.exports = config;
