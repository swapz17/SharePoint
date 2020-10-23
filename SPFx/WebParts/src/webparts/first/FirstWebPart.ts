import * as React from 'react';
import * as ReactDom from 'react-dom';
import { Version } from '@microsoft/sp-core-library';
import {
  BaseClientSideWebPart,
  IPropertyPaneConfiguration,
  PropertyPaneTextField,
  PropertyPaneSlider,
  PropertyPaneDropdown,
  IPropertyPaneDropdownOption
} from '@microsoft/sp-webpart-base';

import * as strings from 'FirstWebPartStrings';
import First from './components/First';
import { IFirstProps } from './components/IFirstProps';

export interface IFirstWebPartProps {
  description: string;
  comment: string;
  tasknumber: number;
  listName : string;
}

export default class FirstWebPart extends BaseClientSideWebPart<IFirstWebPartProps> {
  private lists: IPropertyPaneDropdownOption[];
  private listsDropdownDisabled: boolean = true;
  
  public render(): void {
    const element: React.ReactElement<IFirstProps > = React.createElement(
      First,
      {
        description: this.properties.description,
        comment: this.properties.comment,
        tasknumber : this.properties.tasknumber,
        listName : this.properties.listName
      }
    );

    ReactDom.render(element, this.domElement);
  }

  protected onDispose(): void {
    ReactDom.unmountComponentAtNode(this.domElement);
  }

  protected get dataVersion(): Version {
    return Version.parse('1.0');
  }

  protected getPropertyPaneConfiguration(): IPropertyPaneConfiguration {
    return {
      pages: [
        {
          header: {
            description: strings.PropertyPaneDescription
          },
          groups: [
            {
              groupName: strings.BasicGroupName,
              groupFields: [
                PropertyPaneTextField('description', {
                  label: strings.DescriptionFieldLabel
                }),
                PropertyPaneTextField('comment', {
                  label: strings.CommentFieldLabel
                }),
                PropertyPaneSlider('tasknumber',{
                  label: strings.TaskNumberFieldLabel,min:0,max:10
                }),
                PropertyPaneDropdown('listName',{
                  label: strings.ListNameFieldLabel,
                  options : this.lists,
                  disabled : this.listsDropdownDisabled
                })
              ]
            }
          ]
        }
      ]
    };
  }

  protected onPropertyPaneConfigurationStart(): void {
    this.listsDropdownDisabled = !this.lists;

    if (this.lists) {
      return;
    }

    this.context.statusRenderer.displayLoadingIndicator(this.domElement, 'lists');

    this.loadLists()
      .then((listOptions: IPropertyPaneDropdownOption[]): void => {
        this.lists = listOptions;
        this.listsDropdownDisabled = false;
        this.context.propertyPane.refresh();
        this.context.statusRenderer.clearLoadingIndicator(this.domElement);
        this.render();
      });
  }
 
  // List options for dropdown
  private loadLists(): Promise<IPropertyPaneDropdownOption[]> {
    return new Promise<IPropertyPaneDropdownOption[]>((resolve: (options: IPropertyPaneDropdownOption[]) => void, reject: (error: any) => void) => {
        resolve([{
          key: 'sharedDocuments',
          text: 'Shared Documents'
        },
          {
            key: 'myDocuments',
            text: 'My Documents'
          }]);
    });
  }
}
