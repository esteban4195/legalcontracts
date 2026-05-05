import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

const API = environment.apiUrl;

export interface CloudProvider {
  id: number;
  name: string;
  region: string;
  country: string;
  allows_sensitive_data: boolean;
  location_type: 'DENTRO_PAIS' | 'FUERA_PAIS';
  is_active: boolean;
}

export interface CloudProviderPayload {
  name: string;
  region: string;
  country: string;
  allows_sensitive_data: boolean;
  location_type: 'DENTRO_PAIS' | 'FUERA_PAIS';
}

@Injectable({ providedIn: 'root' })
export class CloudProvidersService {
  constructor(private http: HttpClient) {}

  getAll(): Observable<CloudProvider[]> {
    return this.http.get<CloudProvider[]>(`${API}/cloud-providers`);
  }

  create(payload: CloudProviderPayload): Observable<CloudProvider> {
    return this.http.post<CloudProvider>(`${API}/cloud-providers`, payload);
  }

  update(id: number, payload: Partial<CloudProviderPayload>): Observable<CloudProvider> {
    return this.http.put<CloudProvider>(`${API}/cloud-providers/${id}`, payload);
  }

  toggleActive(id: number): Observable<any> {
    return this.http.patch(`${API}/cloud-providers/${id}/toggle-active`, {});
  }
}
