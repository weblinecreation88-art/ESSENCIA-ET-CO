import Image from "next/image";

export function Cta() {
  return (
    <section id="contact" className="mx-auto max-w-6xl px-6 py-24">
      <div
        className="grid items-center gap-10 overflow-hidden rounded-card px-8 py-16 shadow-soft sm:px-16 lg:grid-cols-[1.2fr_1fr] lg:gap-16"
        style={{
          background:
            "linear-gradient(135deg, #9B74E7 0%, #845DD7 50%, #6F49C8 100%)",
        }}
      >
        <div className="text-center lg:text-left">
          <h2 className="text-3xl font-bold text-white sm:text-4xl">
            Prêt à tester Essencia &amp; Co dans votre établissement ?
          </h2>
          <p className="mx-auto mt-4 max-w-xl text-white/90 lg:mx-0">
            Nous lançons un pilote avec quelques établissements pour valider
            le noyau fonctionnel avant d&apos;aller plus loin. Parlons de
            votre structure et de vos besoins.
          </p>
          <div className="mt-8 flex flex-col items-center justify-center gap-4 sm:flex-row lg:justify-start">
            <a
              href="mailto:contact@essencia-co.fr?subject=Demande%20de%20pilote%20Essencia%20%26%20Co"
              className="rounded-button bg-white px-7 py-3.5 text-base font-semibold text-primary shadow-soft transition hover:bg-white/90"
            >
              Demander une démo pilote
            </a>
            <a
              href="mailto:contact@essencia-co.fr"
              className="rounded-button border border-white/40 px-7 py-3.5 text-base font-semibold text-white transition hover:bg-white/10"
            >
              Nous écrire
            </a>
          </div>
        </div>
        <div className="mx-auto hidden w-full max-w-xs lg:block">
          <Image
            src="/illustrations/caregivers-wheelchair.png"
            alt="Deux aidants accompagnant une résidente, illustration Essencia & Co"
            width={800}
            height={800}
            className="w-full rounded-card"
          />
        </div>
      </div>
    </section>
  );
}
