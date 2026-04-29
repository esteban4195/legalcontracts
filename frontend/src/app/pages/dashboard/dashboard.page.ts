import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-dashboard',
  templateUrl: 'dashboard.page.html',
  styleUrls: ['../placeholder.page.scss'],
  standalone: true,
  imports: [CommonModule],
})
export class DashboardPage {
  user: any;
  constructor(public auth: AuthService) {
    this.user = this.auth.getCurrentUser();
  }
}
