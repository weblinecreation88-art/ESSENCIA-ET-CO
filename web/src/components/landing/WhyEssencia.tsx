import Image from "next/image";
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
      <div className="grid items-center gap-12 lg:grid-cols-2 lg:gap-16">
        <div className="order-2 lg:order-1">
          <h2 className="text-3xl font-bold sm:text-4xl">
            Pourquoi Essencia &amp; Co
          </h2>
          <p className="mt-4 max-w-md text-text-muted">
            Une application conçue pour rassurer, pas pour compliquer — pensée
            pour accompagner chaque résident, quelle que soit sa situation.
          </p>
          <div className="mt-10 grid gap-8 sm:grid-cols-2">
            {pillars.map(({ title, description, icon: Icon }) => (
              <div key={title}>
                <div className="flex h-14 w-14 items-center justify-center rounded-full bg-primary-soft/30">
                  <Icon size={24} strokeWidth={2} className="text-primary-dark" />
                </div>
                <h3 className="mt-4 text-base font-semibold text-title">
                  {title}
                </h3>
                <p className="mt-1 text-sm text-text-muted">{description}</p>
              </div>
            ))}
          </div>
        </div>
        <div className="order-1 mx-auto w-full max-w-sm lg:order-2 lg:max-w-none">
          <Image
            src="/illustrations/family-wheelchair.png"
            alt="Une résidente en fauteuil roulant entourée de sa famille, illustration Essencia & Co"
            width={1200}
            height={1200}
            className="w-full rounded-card shadow-soft"
          />
        </div>
      </div>
    </section>
  );
}
