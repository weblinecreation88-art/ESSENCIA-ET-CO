import { BellRing, HeartHandshake, ShieldCheck, Users } from "lucide-react";

const pillars = [
  {
    title: "Sécurisé",
    description: "Données protégées et confidentialité respectée.",
    icon: ShieldCheck,
  },
  {
    title: "Notifications",
    description: "Ne manquez rien d'important.",
    icon: BellRing,
  },
  {
    title: "Bienveillance",
    description: "Au cœur de chaque fonctionnalité.",
    icon: HeartHandshake,
  },
  {
    title: "Accompagnement",
    description: "Une équipe à votre écoute.",
    icon: Users,
  },
];

export function WhyEssencia() {
  return (
    <section id="pourquoi" className="mx-auto max-w-6xl px-6 py-24">
      <div className="mx-auto max-w-2xl text-center">
        <h2 className="text-3xl font-bold sm:text-4xl">Pourquoi Essencia &amp; Co</h2>
        <p className="mt-4 text-text-muted">
          Une application conçue pour rassurer, pas pour compliquer.
        </p>
      </div>
      <div className="mt-14 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {pillars.map(({ title, description, icon: Icon }) => (
          <div key={title} className="text-center">
            <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-full bg-primary-soft/30">
              <Icon size={24} strokeWidth={2} className="text-primary-dark" />
            </div>
            <h3 className="mt-4 text-base font-semibold text-title">{title}</h3>
            <p className="mt-1 text-sm text-text-muted">{description}</p>
          </div>
        ))}
      </div>
    </section>
  );
}
