export default {
  build: {
    publicFolder: "static",
    outputFolder: "public",
  },
  schema: {
    collections: [
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
        name: "posts",
        label: "Posts",
        path: "content/posts",
        fields: [
          { type: "string", name: "title", label: "Title", isTitle: true, required: true },
          { type: "datetime", name: "date", label: "Date" },
          { type: "rich-text", name: "body", label: "Body", isBody: true },
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