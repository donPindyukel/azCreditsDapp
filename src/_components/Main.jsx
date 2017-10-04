import React, { Component } from 'react';
import { Router, Route, Switch, IndexRoute } from 'react-router-dom';
import { history } from '../_helpers';

import { OpenLoans } from './OpenLoans';
import { LoansRequests } from './LoansRequests';
import { HomePage } from '../HomePage';

export class Main extends Component {
    render () {
        console.log('sdsaf',this.props);
        return (
            <div>
               {this.props.children}
            </div>
        )
    }
}
