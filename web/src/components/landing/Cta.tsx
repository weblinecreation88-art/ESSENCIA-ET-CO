export function Cta() {
  return (
    <section id="contact" className="mx-auto max-w-6xl px-6 py-24">
      <div
        className="rounded-card px-8 py-16 text-center shadow-soft sm:px-16"
        style={{
          background:
            "linear-gradient(135deg, #9B74E7 0%, #845DD7 50%, #6F49C8 100%)",
        }}
      >
        <h2 className="text-3xl font-bold text-white sm:text-4xl">
          Prêt à tester Essencia &amp; Co dans votre établissement ?
        </h2>
        <p className="mx-auto mt-4 max-w-xl text-white/90">
          Nous lançons un pilote avec quelques établissements pour valider le
          noyau fonctionnel avant d&apos;aller plus loin. Parlons de votre
          structure et de vos besoins.
        </p>
        <div className="mt-8 flex flex-col items-center justify-center gap-4 sm:flex-row">
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
    </section>
  );
}
