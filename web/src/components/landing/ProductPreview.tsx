import {
  Bell,
  Calendar,
  Camera,
  Home,
  MessageCircle,
  User,
} from "lucide-react";

function PhoneFrame({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <div className="flex w-64 flex-shrink-0 flex-col rounded-[2.5rem] border border-border bg-surface p-3 shadow-soft">
      <div className="flex-1 rounded-[2rem] bg-surface-alt p-4">
        <p className="mb-3 text-xs font-semibold uppercase tracking-wide text-text-muted">
          {title}
        </p>
        {children}
      </div>
      <div className="mt-3 flex items-center justify-around rounded-full bg-surface py-2 text-text-muted">
        <Home size={16} />
        <MessageCircle size={16} />
        <Calendar size={16} />
        <User size={16} />
      </div>
    </div>
  );
}

export function ProductPreview() {
  return (
    <section id="apercu" className="bg-surface-alt py-24">
      <div className="mx-auto max-w-6xl px-6">
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="text-3xl font-bold sm:text-4xl">
            Une application claire, pensée pour tous les âges
          </h2>
          <p className="mt-4 text-text-muted">
            Beaucoup d&apos;espace blanc, des cartes flottantes, des angles
            arrondis : une interface rassurante et accessible, y compris pour
            un public senior.
          </p>
        </div>

        <div className="mt-14 flex gap-6 overflow-x-auto pb-4">
          <PhoneFrame title="Bonjour Marie 👋">
            <div className="space-y-3">
              <div className="rounded-card bg-surface p-3 shadow-soft">
                <p className="flex items-center gap-2 text-xs font-medium text-primary">
                  <Bell size={14} /> Prochain rendez-vous
                </p>
                <p className="mt-1 text-sm font-semibold text-title">
                  Coiffeur — Aujourd&apos;hui 14h30
                </p>
              </div>
              <div className="grid grid-cols-2 gap-2">
                {["Ma famille", "Messages", "Photos", "Agenda"].map((label) => (
                  <div
                    key={label}
                    className="rounded-field bg-surface px-3 py-2 text-xs font-medium text-text shadow-soft"
                  >
                    {label}
                  </div>
                ))}
              </div>
            </div>
          </PhoneFrame>

          <PhoneFrame title="Mon agenda — Mai 2024">
            <div className="space-y-2">
              {[
                ["14:30", "Coiffeur", "Avec Sophie"],
                ["15:30", "Atelier lecture", "Salle d'animation"],
                ["19:00", "Appel vidéo", "Avec Julie"],
              ].map(([time, title, subtitle]) => (
                <div
                  key={time}
                  className="rounded-field bg-surface px-3 py-2 shadow-soft"
                >
                  <p className="text-xs font-semibold text-primary">{time}</p>
                  <p className="text-sm font-medium text-title">{title}</p>
                  <p className="text-xs text-text-muted">{subtitle}</p>
                </div>
              ))}
            </div>
          </PhoneFrame>

          <PhoneFrame title="Réserver un service">
            <div className="space-y-2">
              {[
                ["Coiffeur", "#8C68D5"],
                ["Esthétique / Bien-être", "#E75E9D"],
                ["Activités / Animations", "#59B37D"],
                ["Autres services", "#F6A53A"],
              ].map(([label, color]) => (
                <div
                  key={label}
                  className="flex items-center justify-between rounded-field bg-surface px-3 py-2 text-sm font-medium text-title shadow-soft"
                >
                  <span className="flex items-center gap-2">
                    <span
                      className="h-2 w-2 rounded-full"
                      style={{ backgroundColor: color }}
                    />
                    {label}
                  </span>
                  <span className="text-text-muted">›</span>
                </div>
              ))}
            </div>
          </PhoneFrame>

          <PhoneFrame title="Galerie — Établissement">
            <div className="grid grid-cols-3 gap-1.5">
              {Array.from({ length: 9 }).map((_, i) => (
                <div
                  key={i}
                  className="flex aspect-square items-center justify-center rounded-md bg-primary-soft/40"
                >
                  <Camera size={14} className="text-primary" />
                </div>
              ))}
            </div>
          </PhoneFrame>
        </div>
      </div>
    </section>
  );
}
