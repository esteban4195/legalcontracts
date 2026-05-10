import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

// export interface DashboardSummary {
//     total_contracts: number;
//     firmados: number;
//     contracts_by_month: { month: string; count: number }[];
//     recent_activity: { action: string; timestamp: string }[];
//     recent_contracts: any[];
// }

export interface RecentContract {
    id: number;
    title: string;
    status: string;
    provider: string;
    date: string;
}

export interface DashboardSummary {
    total_contracts: number;
    firmados: number;
    validated_contracts?: number;
    borradores?: number;
    recent_contracts: RecentContract[];
}

@Injectable({
    providedIn: 'root'
})
export class DashboardService {
    private apiUrl = environment.apiUrl || 'http://localhost:8000';

    constructor(private http: HttpClient) { }

    getSummary(): Observable<DashboardSummary> {
        return this.http.get<DashboardSummary>(`${this.apiUrl}/dashboard/summary`);
    }
}