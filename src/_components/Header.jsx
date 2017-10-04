import React, { Component } from 'react';
import { Link } from 'react-router';

export class Header extends Component {
    render () {
        return (
            <nav className="navbar navbar-expand-lg navbar-dark bg-dark">
                <a className="navbar-brand" href="#">AzCredit</a>
                <div className="collapse navbar-collapse" id="navbarNav">
                    <ul className="navbar-nav">
                        <li className="nav-item active">
                            <a className="nav-link" href="#">Открытые займы<span className="sr-only">(current)</span></a>
                        </li>
                        <li className="nav-item">
                            <a className="nav-link" href="#">Заявки на займы</a>
                        </li>
                    </ul>
                </div>
            </nav>
        )
    }
}
