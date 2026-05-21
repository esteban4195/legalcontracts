import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

const API = environment.apiUrl;

export interface AuditLog {
  id: number;
  created_at: string;
  action_type: string;
  contract_id: number | null;
  user_id: number;
  user_name: string;
  description: string;
}

@Injectable({
  providedIn: 'root'
})
export class AuditLogsService {

  constructor(private http: HttpClient) {}

  getAll(filters?: {
    action_type?: string;
  }): Observable<AuditLog[]> {

    let params = new HttpParams();

    if (filters?.action_type) {
      params = params.set('action_type', filters.action_type);
    }

    return this.http.get<AuditLog[]>(
      `${API}/audit-logs`,
      { params }
    );
  }
}