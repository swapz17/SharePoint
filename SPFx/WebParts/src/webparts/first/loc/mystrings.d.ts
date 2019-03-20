declare interface IFirstWebPartStrings {
  PropertyPaneDescription: string;
  PropertyPaneComment: string;
  BasicGroupName: string;
  DescriptionFieldLabel: string;
  CommentFieldLabel: string;
  TaskNumberFieldLabel: string;
  ListNameFieldLabel: string;
}

declare module 'FirstWebPartStrings' {
  const strings: IFirstWebPartStrings;
  export = strings;
}
