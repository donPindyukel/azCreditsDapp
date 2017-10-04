import React from 'react';
import { Switch, Router, Route, IndexRoute, Redirect } from 'react-router-dom';
import { connect } from 'react-redux';

import { history } from '../_helpers';
import { alertActions } from '../_actions';
import { PrivateRoute, LoansRequests } from '../_components';
import { HomePage } from '../HomePage';
import { LoginPage } from '../LoginPage';
import { RegisterPage } from '../RegisterPage';
import { AdminPage } from '../AdminPage';
import { OpenLoans } from '../_components';
import { Main } from '../_components';

class App extends React.Component {
    constructor(props) {
        super(props);

        const { dispatch } = this.props;
        history.listen((location, action) => {
            // clear alert on location change
            dispatch(alertActions.clear());
        });
    }

    render() {
        const { alert } = this.props;
        return (
                    <div>
                        {alert.message &&
                            <div className={`alert ${alert.type}`}>{alert.message}</div>
                        }
                        <Router history={history}>
                            <div>
                            <Route exact path="/" render={() => (
                                   < Redirect to="/open"/>
                                 )} />
                            <HomePage>
                                <Route path="/open" component={OpenLoans} />
                                <Route path="/name" component={LoansRequests} />
                            </HomePage>
                                <PrivateRoute path="/admin" component={AdminPage}/>
                                <Route path="/login" component={LoginPage} />
                                <Route path="/register" component={RegisterPage} />
                            </div>
                        </Router>
                    </div>
        );
    }
}

function mapStateToProps(state) {
    const { alert } = state;
    return {
        alert
    };
}

const connectedApp = connect(mapStateToProps)(App);
export { connectedApp as App }; 