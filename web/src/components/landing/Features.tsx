import {
  Bell,
  Calendar,
  CalendarCheck,
  Camera,
  MessageCircle,
  RefreshCw,
  ShieldCheck,
  UserCircle,
} from "lucide-react";

const features = [
  {
    title: "Connexion sécurisée",
    description: "Un accès simple et protégé, adapté à chaque rôle.",
    icon: ShieldCheck,
    color: "#8c68d5",
    tint: "#f3eefc",
  },
  {
    title: "Profils multi-rôles",
    description: "Résident, famille, professionnel, prestataire, admin.",
    icon: UserCircle,
    color: "#e75e9d",
    tint: "#fceff5",
  },
  {
    title: "Messagerie",
    description: "Restez en contact avec vos proches et l'équipe.",
    icon: MessageCircle,
    color: "#59b37d",
    tint: "#eaf6ef",
  },
  {
    title: "Photos",
    description: "Partagez les moments du quotidien en toute simplicité.",
    icon: Camera,
    color: "#f6a53a",
    tint: "#fdf2e4",
  },
  {
    title: "Agenda partagé",
    description: "Rendez-vous, activités et visites, toujours à jour.",
    icon: Calendar,
    color: "#8c68d5",
    tint: "#f3eefc",
  },
  {
    title: "Réservation de services",
    description: "Coiffeur, esthétique, animations, prestataires locaux.",
    icon: CalendarCheck,
    color: "#e75e9d",
    tint: "#fceff5",
  },
  {
    title: "Notifications",
    description: "Confirmations, rappels et suivi de statut en temps réel.",
    icon: Bell,
    color: "#59b37d",
    tint: "#eaf6ef",
  },
  {
    title: "Seconde vie",
    description: "Don, vente ou location de matériel entre résidences.",
    icon: RefreshCw,
    color: "#f6a53a",
    tint: "#fdf2e4",
  },
];

export function Features() {
  return (
    <section className="bg-surface-alt py-24">
      <div className="mx-auto max-w-6xl px-6">
        <div className="mx-auto flex max-w-xl flex-col gap-4 text-center">
          <span className="text-sm font-bold uppercase tracking-[0.08em] text-primary">
            Fonctionnalités
          </span>
          <h2 className="text-[clamp(2rem,3.4vw,2.7rem)] font-extrabold tracking-[-0.02em]">
            Tout ce qu&apos;il faut, rien de superflu
          </h2>
          <p className="text-lg leading-relaxed text-text-muted">
            Le noyau fonctionnel d&apos;Essencia &amp; Co, pensé pour l&apos;essentiel.
          </p>
        </div>
        <div className="mt-14 grid gap-[22px] sm:grid-cols-2 lg:grid-cols-4">
          {features.map(({ title, description, icon: Icon, color, tint }) => (
            <div
              key={title}
              className="rounded-[20px] border border-border bg-surface p-[26px] shadow-[0_8px_24px_rgba(70,40,120,0.05)] transition-all duration-200 hover:-translate-y-1 hover:shadow-[0_18px_40px_rgba(70,40,120,0.1)]"
            >
              <span
                className="flex h-12 w-12 items-center justify-center rounded-[14px]"
                style={{ backgroundColor: tint }}
              >
                <Icon size={22} strokeWidth={2} color={color} />
              </span>
              <h3 className="mt-[18px] text-[1.05rem] font-bold text-title">{title}</h3>
              <p className="mt-2 text-[0.96rem] leading-relaxed text-text-muted">
                {description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
