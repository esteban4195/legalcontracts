import { Component, OnInit } from "@angular/core";
import { CommonModule } from "@angular/common";
import { FormsModule } from "@angular/forms";
import { AuditLogsService, AuditLog } from "../../services/audit-logs.service";

@Component({
  selector: "app-audit-logs",
  templateUrl: "audit-logs.page.html",
  styleUrls: ["audit-logs.page.scss"],
  standalone: true,
  imports: [CommonModule, FormsModule],
})
export class AuditLogsPage implements OnInit {
  // Simulación temporal de logs a espera de backend (Nasly)
  logs: AuditLog[] = [];
  filteredLogs: AuditLog[] = [];

  constructor(private auditLogsService: AuditLogsService) {}

  selectedAction: string = "";
  selectedUser: string = "";

  isForbidden = false;
  isLoading = false;

  get totalEventos(): number {
    return this.logs.length;
  }

  get totalFirmas(): number {
    return this.logs.filter((log) => log.accion === "FIRMA").length;
  }

  get totalValidaciones(): number {
    return this.logs.filter((log) => log.accion === "VALIDACION").length;
  }

  ngOnInit(): void {

  this.isLoading = true;

  this.auditLogsService.getAll().subscribe({

    next: (resp) => {

      this.logs = resp;
      this.filteredLogs = [...resp];

      this.isLoading = false;
    },

    error: (err) => {

      this.isLoading = false;

      if (err.status === 403) {
        this.isForbidden = true;
      }
    }
  });
}

  applyFilters(): void {
    this.filteredLogs = this.logs.filter((log) => {
      const matchAction =
        !this.selectedAction ||
        log.accion.toLowerCase().includes(this.selectedAction.toLowerCase());

      const matchUser =
        !this.selectedUser ||
        log.usuario.toLowerCase().includes(this.selectedUser.toLowerCase());

      return matchAction && matchUser;
    });
  }

  getActionClass(action: string): string {
    switch (action) {
      case "LOGIN":
        return "badge-login";

      case "LOGOUT":
        return "badge-logout";

      case "FIRMA":
        return "badge-sign";

      case "VALIDACION":
        return "badge-validation";

      case "CREACION_CONTRATO":
        return "badge-create";

      case "AGREGAR_PARTICIPANTE":
        return "badge-add";

      case "ELIMINAR_PARTICIPANTE":
        return "badge-remove";

      case "EDICION_CONTRATO":
        return "badge-edit";

      case "ERROR_VALIDACION_PROVEEDOR":
        return "badge-error";

      default:
        return "badge-default";
    }
  }
}
