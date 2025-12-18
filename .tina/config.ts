export default {
  build: {
    command: "hugo server --port 1313",
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
        label: "Notes",
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
          { type: "rich-text", name: "body", label: "Body", isBody: true },
        ],
      },
      {
        name: "config",
        label: "Site Config",
        path: "content/config",
        format: "yaml",
        ui: { allowedActions: { create: false, delete: false } },
        fields: [
          { type: "string", name: "title", label: "Site Title" },
          { type: "string", name: "description", label: "Site Description" },
          { type: "string", name: "baseURL", label: "Base URL" },
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