import Image from "next/image";

export function Hero() {
  return (
    <section className="relative overflow-hidden">
      <div
        className="absolute inset-x-0 top-0 -z-10 h-[640px]"
        style={{
          background:
            "linear-gradient(135deg, #9B74E7 0%, #845DD7 50%, #6F49C8 100%)",
          maskImage: "linear-gradient(to bottom, black, transparent)",
          WebkitMaskImage: "linear-gradient(to bottom, black, transparent)",
        }}
      />
      <div className="mx-auto grid max-w-6xl items-center gap-12 px-6 pb-24 pt-20 lg:grid-cols-2 lg:gap-16">
        <div className="flex flex-col items-center gap-8 text-center lg:items-start lg:text-left">
          <Image
            src="/logo.png"
            alt="Essencia & Co — Le lien qui prend soin de l'essentiel"
            width={80}
            height={80}
            className="rounded-card shadow-soft"
            priority
          />
          <div className="space-y-4">
            <h1 className="text-4xl font-bold text-white drop-shadow-sm sm:text-5xl">
              Essencia &amp; Co
            </h1>
            <p className="text-lg font-medium text-white/90 sm:text-xl">
              Le lien qui prend soin de l&apos;essentiel
            </p>
          </div>
          <p className="max-w-xl text-balance text-base text-white/90 sm:text-lg">
            Rapprocher les cœurs, faciliter le quotidien. Essencia &amp; Co
            connecte résidents, familles, équipes et prestataires en EHPAD et
            résidences seniors : messagerie, agenda, réservation de services
            et notifications, dans une application simple et rassurante.
          </p>
          <div className="flex flex-col gap-4 sm:flex-row">
            <a
              href="#contact"
              className="rounded-button bg-white px-7 py-3.5 text-base font-semibold text-primary shadow-soft transition hover:bg-white/90"
            >
              Demander une démo pilote
            </a>
            <a
              href="#apercu"
              className="rounded-button border border-white/40 px-7 py-3.5 text-base font-semibold text-white transition hover:bg-white/10"
            >
              Découvrir l&apos;application
            </a>
          </div>
        </div>
        <div className="relative mx-auto w-full max-w-md lg:max-w-none">
          <Image
            src="/illustrations/hero-family.png"
            alt="Une résidente entourée de sa famille, illustration Essencia & Co"
            width={1200}
            height={1200}
            className="w-full rounded-card shadow-soft"
            priority
          />
        </div>
      </div>
    </section>
  );
}
