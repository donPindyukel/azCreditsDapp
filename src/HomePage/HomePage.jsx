import React from 'react';
import { Router, Route, Switch, IndexRoute } from 'react-router-dom';
import { connect } from 'react-redux';

import { web3 } from '../_helpers';
import { userActions } from '../_actions';

import { Main } from '../_components';
import { Header } from '../_components';
import { CoinInfo } from '../_components';

import { OpenLoans } from '../_components';
import { LoansRequests, PrivateRoute } from '../_components';

class HomePage extends React.Component {
    componentDidMount() {
        this.props.dispatch(userActions.getAll());
    }

    handleDeleteUser(id) {
        return (e) => this.props.dispatch(userActions.delete(id));
    }

    render() {
        console.log(this.props.children);
        const { user, users } = this.props;
       /* web3.eth.getAccounts((err, res) => {
            console.log(res);
        })*/
        return (
            <div>
                <Header/>
                <CoinInfo/>
                {this.props.children}
            </div>
        );
    }
}

function mapStateToProps(state) {
    const { users, authentication } = state;
    const { user } = authentication;
    return {
        user,
        users
    };
}

const connectedHomePage = connect(mapStateToProps)(HomePage);
export { connectedHomePage as HomePage };