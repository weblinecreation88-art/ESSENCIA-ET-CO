import Image from "next/image";
import { BellRing, Heart, ShieldCheck, Users } from "lucide-react";

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
    icon: Heart,
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
      <div className="grid items-center gap-[72px] lg:grid-cols-2">
        <div className="relative mx-auto w-full max-w-[440px]">
          <div
            className="absolute -inset-x-[6%] -inset-y-[5%] rotate-3 rounded-[36px]"
            style={{ background: "linear-gradient(150deg,#fbeaf3,#efe7fb)" }}
          />
          <Image
            src="/illustrations/family-wheelchair.png"
            alt="Une résidente en fauteuil roulant entourée de sa famille, illustration Essencia & Co"
            width={1200}
            height={1200}
            className="relative block w-full rounded-[30px] shadow-[0_26px_56px_rgba(70,40,120,0.14)]"
          />
        </div>
        <div>
          <span className="text-sm font-bold uppercase tracking-[0.08em] text-primary">
            Pourquoi nous
          </span>
          <h2 className="mt-3.5 text-[clamp(2rem,3.4vw,2.7rem)] font-extrabold tracking-[-0.02em]">
            Rassurer, jamais compliquer
          </h2>
          <p className="mt-4 max-w-md text-lg leading-relaxed text-text-muted">
            Une application pensée pour accompagner chaque résident, quelle que soit sa
            situation — avec douceur et simplicité.
          </p>
          <div className="mt-10 grid gap-[18px] sm:grid-cols-2">
            {pillars.map(({ title, description, icon: Icon }) => (
              <div
                key={title}
                className="rounded-[18px] border border-border bg-surface p-6 shadow-[0_8px_22px_rgba(70,40,120,0.05)] transition-all duration-200 hover:-translate-y-1 hover:shadow-[0_18px_38px_rgba(70,40,120,0.11)]"
              >
                <span
                  className="flex h-[52px] w-[52px] items-center justify-center rounded-[15px]"
                  style={{ background: "linear-gradient(145deg,#f3eefc,#e8ddf9)" }}
                >
                  <Icon size={25} strokeWidth={2} className="text-primary-dark" />
                </span>
                <h3 className="mt-4 text-[1.12rem] font-bold text-title">{title}</h3>
                <p className="mt-1.5 text-base text-text-muted">{description}</p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
