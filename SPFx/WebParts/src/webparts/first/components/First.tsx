import * as React from 'react';
import styles from './First.module.scss';
import { IFirstProps } from './IFirstProps';
import { escape } from '@microsoft/sp-lodash-subset';

export default class First extends React.Component<IFirstProps, {}> {
  public render(): React.ReactElement<IFirstProps> {
    return (
      <div className={ styles.first }>
        <div className={ styles.container }>
          <div className={ styles.row }>
            <div className={ styles.column }>
              <span className={ styles.title }>Welcome to SharePoint!</span>
              <p className={ styles.subTitle }>My First Webpart.</p>
              <p className={ styles.description }>{escape(this.props.description)}</p>
              <p className={ styles.comment }>{escape(this.props.comment)}</p>
              <p className={ styles.comment }>{escape(this.props.tasknumber.toString())}</p>
              <a href='https://aka.ms/spfx' className={ styles.button }>
                <span className={ styles.label }>Learn more</span>
              </a>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
