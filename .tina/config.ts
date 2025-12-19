export default {
  build: {
    command: "hugo server --bind 0.0.0.0 --port 1313 --disableFastRender",
    publicFolder: "static",
    outputFolder: "public",
  },
  schema: {
    collections: [
      {
        name: "home",
        label: "Home Page",
        path: "content",
        match: { include: "_index*" },
        ui: { allowedActions: { create: false, delete: false } },
        fields: [
          { type: "string", name: "title", label: "Title", isTitle: true, required: true },
          { type: "rich-text", name: "body", label: "Body", isBody: true },
        ],
      },
      {
        name: "posts",
        label: "Posts",
        path: "content/posts",
        fields: [
          { type: "string", name: "title", label: "Title", isTitle: true, required: true },
          { type: "datetime", name: "date", label: "Date" },
          { type: "rich-text", name: "body", label: "Body", isBody: true },
        ],
      },
      {
        name: "notes",
        label: "Blog",
        path: "content/notes",
        fields: [
          { type: "string", name: "title", label: "Title", isTitle: true, required: true },
          { type: "rich-text", name: "body", label: "Body", isBody: true },
        ],
      },
      {
        name: "photos",
        label: "Photos",
        path: "content/photos",
        fields: [
          { type: "string", name: "title", label: "Title", isTitle: true, required: true },
          { type: "image", name: "image", label: "Image" },
          { type: "rich-text", name: "body", label: "Body", isBody: true },
        ],
      },
      {
        name: "about",
        label: "About",
        path: "content/about",
        fields: [
          { type: "string", name: "title", label: "Title", isTitle: true, required: true },
          { type: "rich-text", name: "body", label: "Body", isBody: true },
        ],
      },
      {
        name: "pages",
        label: "Pages",
        path: "content/pages",
        fields: [
          { type: "string", name: "title", label: "Title", isTitle: true, required: true },
          { type: "string", name: "menu", label: "Menu (e.g., main)" },
          { type: "boolean", name: "draft", label: "Draft" },
          { type: "rich-text", name: "body", label: "Body", isBody: true },
        ],
      },
      {
        name: "siteConfig",
        label: "Site Config",
        path: "",
        match: { include: "config*" },
        format: "yaml",
        ui: { allowedActions: { create: false, delete: false } },
        fields: [
          { type: "string", name: "title", label: "Site Title" },
          { type: "string", name: "baseURL", label: "Base URL" },
          { type: "string", name: "description", label: "Site Description" },
          { type: "string", name: "theme", label: "Theme" },
          {
            type: "object",
            name: "menu",
            label: "Menu",
            fields: [
              {
                type: "object",
                name: "main",
                label: "Main Menu",
                list: true,
                fields: [
                  { type: "string", name: "identifier", label: "Identifier" },
                  { type: "string", name: "name", label: "Name" },
                  { type: "string", name: "url", label: "URL" },
                  { type: "number", name: "weight", label: "Weight" },
                ],
              },
            ],
          },
          {
            type: "object",
            name: "params",
            label: "Params",
            fields: [
              {
                type: "object",
                name: "hero",
                label: "Hero",
                fields: [
                  {
                    type: "image",
                    name: "background_image",
                    label: "Background Image",
                  },
                ],
              },
              {
                type: "object",
                name: "footer",
                label: "Footer",
                fields: [
                  {
                    type: "string",
                    name: "copyright",
                    label: "Copyright Text",
                  },
                ],
              },
            ],
          },
        ],
      },
    ],
  },
  media: {
    tina: {
      mediaRoot: "static/img",
      publicFolder: "static",
    },
  },
};