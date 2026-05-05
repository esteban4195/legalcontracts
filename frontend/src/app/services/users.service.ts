import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

const API = environment.apiUrl;

export interface User {
  id: number;
  name: string;
  email: string;
  system_role: 'ADMIN' | 'USUARIO' | 'AUDITOR';
  is_active: boolean;
}

export interface UserCreatePayload {
  name: string;
  email: string;
  password: string;
  system_role: string;
}

export interface UserUpdatePayload {
  name?: string;
  email?: string;
  system_role?: string;
}

@Injectable({ providedIn: 'root' })
export class UsersService {
  constructor(private http: HttpClient) {}

  getAll(): Observable<User[]> {
    return this.http.get<User[]>(`${API}/users`);
  }

  create(payload: UserCreatePayload): Observable<User> {
    return this.http.post<User>(`${API}/users`, payload);
  }

  update(id: number, payload: UserUpdatePayload): Observable<User> {
    return this.http.put<User>(`${API}/users/${id}`, payload);
  }

  toggleActive(id: number): Observable<any> {
    return this.http.patch(`${API}/users/${id}/toggle-active`, {});
  }
}
