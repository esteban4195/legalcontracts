import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule, RouterOutlet } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-main-layout',
  templateUrl: 'main-layout.component.html',
  styleUrls: ['main-layout.component.scss'],
  standalone: true,
  imports: [CommonModule, RouterModule, RouterOutlet],
})
export class MainLayoutComponent {
  constructor(public auth: AuthService, private router: Router) {}

  get currentUser() {
    return this.auth.getCurrentUser();
  }

  isActive(route: string): boolean {
    return this.router.url === route || this.router.url.startsWith(route + '/');
  }

  logout(): void {
    this.auth.logout();
  }
}
