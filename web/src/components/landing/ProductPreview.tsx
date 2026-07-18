import {
  Bell,
  Calendar,
  Camera,
  Home,
  MessageCircle,
  MoveRight,
  User,
} from "lucide-react";

function PhoneFrame({
  title,
  activeTab = "home",
  children,
}: {
  title: string;
  activeTab?: "home" | "messages" | "agenda" | "profil";
  children: React.ReactNode;
}) {
  const tabColor = (tab: string) => (tab === activeTab ? "#8c68d5" : "#b8bdc8");
  return (
    <div className="w-[270px] flex-none snap-center rounded-[38px] border border-border bg-surface p-3.5 shadow-[0_24px_50px_rgba(70,40,120,0.12)]">
      <div className="rounded-[28px] bg-surface-alt p-5">
        <p className="mb-4 text-[0.72rem] font-bold uppercase tracking-wide text-text-muted">
          {title}
        </p>
        {children}
      </div>
      <div className="mt-3 flex items-center justify-around px-1 py-2.5">
        <Home size={19} color={tabColor("home")} />
        <MessageCircle size={19} color={tabColor("messages")} />
        <Calendar size={19} color={tabColor("agenda")} />
        <User size={19} color={tabColor("profil")} />
      </div>
    </div>
  );
}

const services: [string, string][] = [
  ["Coiffeur", "#8c68d5"],
  ["Bien-être", "#e75e9d"],
  ["Animations", "#59b37d"],
  ["Autres services", "#f6a53a"],
];

const galleryTints = ["#e8dcf8", "#f7dceb", "#dcf0e6", "#fae6cf"];
const galleryStrokes = ["#8c68d5", "#e75e9d", "#59b37d", "#f6a53a"];

export function ProductPreview() {
  return (
    <section id="apercu" className="bg-surface-alt py-24">
      <div className="mx-auto max-w-6xl px-6">
        <div className="mx-auto flex max-w-2xl flex-col gap-4 text-center">
          <span className="text-sm font-bold uppercase tracking-[0.08em] text-primary">
            L&apos;application
          </span>
          <h2 className="text-[clamp(2rem,3.4vw,2.7rem)] font-extrabold tracking-[-0.02em]">
            Claire, pensée pour tous les âges
          </h2>
          <p className="text-lg leading-relaxed text-text-muted">
            Beaucoup d&apos;espace, des cartes douces et des angles arrondis : une interface
            rassurante et accessible, y compris pour un public senior.
          </p>
          <span className="mt-1 inline-flex items-center justify-center gap-2 text-sm font-semibold text-primary">
            Glissez pour découvrir les écrans <MoveRight size={17} strokeWidth={2.2} />
          </span>
        </div>

        <div className="mt-14 flex snap-x snap-mandatory gap-[26px] overflow-x-auto px-1 pb-5 pt-2">
          <PhoneFrame title="Bonjour Marie 👋" activeTab="home">
            <div className="space-y-3">
              <div className="rounded-2xl bg-surface p-3.5 shadow-[0_8px_20px_rgba(70,40,120,0.07)]">
                <p className="flex items-center gap-[7px] text-[0.78rem] font-semibold text-primary">
                  <Bell size={15} strokeWidth={2.2} /> Prochain rendez-vous
                </p>
                <p className="mt-1.5 text-[0.95rem] font-bold text-title">Coiffeur — 14h30</p>
              </div>
              <div className="grid grid-cols-2 gap-[9px]">
                {["Ma famille", "Messages", "Photos", "Agenda"].map((label) => (
                  <div
                    key={label}
                    className="rounded-xl bg-surface px-3 py-[11px] text-[0.82rem] font-semibold text-text shadow-[0_6px_16px_rgba(70,40,120,0.06)]"
                  >
                    {label}
                  </div>
                ))}
              </div>
            </div>
          </PhoneFrame>

          <PhoneFrame title="Mon agenda — Mai" activeTab="agenda">
            <div className="space-y-[9px]">
              {[
                ["14:30", "Coiffeur", "Avec Sophie", "#8c68d5"],
                ["15:30", "Atelier lecture", "Salle d'animation", "#e75e9d"],
                ["19:00", "Appel vidéo", "Avec Julie", "#59b37d"],
              ].map(([time, title, subtitle, color]) => (
                <div
                  key={time}
                  className="rounded-[14px] bg-surface px-[13px] py-[11px] shadow-[0_6px_16px_rgba(70,40,120,0.06)]"
                >
                  <p className="text-[0.78rem] font-bold" style={{ color }}>
                    {time}
                  </p>
                  <p className="text-[0.92rem] font-semibold text-title">{title}</p>
                  <p className="text-[0.78rem] text-text-muted">{subtitle}</p>
                </div>
              ))}
            </div>
          </PhoneFrame>

          <PhoneFrame title="Réserver un service" activeTab="agenda">
            <div className="space-y-[9px]">
              {services.map(([label, color]) => (
                <div
                  key={label}
                  className="flex items-center justify-between rounded-[14px] bg-surface px-[13px] py-3 shadow-[0_6px_16px_rgba(70,40,120,0.06)]"
                >
                  <span className="flex items-center gap-[9px] text-[0.9rem] font-semibold text-title">
                    <span
                      className="h-[9px] w-[9px] rounded-full"
                      style={{ backgroundColor: color }}
                    />
                    {label}
                  </span>
                  <span className="text-text-disabled">›</span>
                </div>
              ))}
            </div>
          </PhoneFrame>

          <PhoneFrame title="Galerie — Établissement" activeTab="messages">
            <div className="grid grid-cols-3 gap-[7px]">
              {Array.from({ length: 9 }).map((_, i) => (
                <div
                  key={i}
                  className="flex aspect-square items-center justify-center rounded-[10px]"
                  style={{ backgroundColor: galleryTints[i % 4] }}
                >
                  <Camera size={15} color={galleryStrokes[i % 4]} />
                </div>
              ))}
            </div>
          </PhoneFrame>
        </div>
      </div>
    </section>
  );
}
