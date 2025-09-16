import Link from 'next/link';

export default function HomePage() {
  return (
    <main className="flex flex-1 flex-col justify-center text-center">
      <h1 className="mb-4 text-4xl font-bold">Arch Network Documentation</h1>
      <p className="mb-8 text-lg text-fd-muted-foreground">
        A Bitcoin-native computation environment that enhances Bitcoin's capabilities through specialized virtual machine operations
      </p>
      <div className="flex gap-4 justify-center">
        <Link
          href="/docs/"
          className="px-6 py-3 bg-fd-primary text-fd-primary-foreground rounded-lg font-semibold hover:bg-fd-primary/90 transition-colors"
        >
          View Documentation
        </Link>
        <Link
          href="/docs/getting-started/quick-start"
          className="px-6 py-3 border border-fd-border rounded-lg font-semibold hover:bg-fd-muted transition-colors"
        >
          Quick Start
        </Link>
      </div>
    </main>
  );
}
