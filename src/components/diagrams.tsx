import type { ReactNode } from 'react';

type PipelineStep = {
  label: string;
  sub?: string;
  ref?: string;
};

export function Pipeline({ steps }: { steps: PipelineStep[] }) {
  return (
    <div className="not-prose my-6 flex flex-wrap items-stretch gap-2">
      {steps.map((step, i) => (
        <div key={step.label} className="flex items-stretch gap-2">
          <div className="flex min-w-32 flex-1 flex-col justify-center rounded-xl border border-fd-border bg-fd-card px-4 py-3 text-center shadow-sm">
            <span className="text-sm font-medium text-fd-foreground">
              {step.label}
            </span>
            {step.sub ? (
              <span className="mt-0.5 font-mono text-xs text-fd-muted-foreground">
                {step.sub}
              </span>
            ) : null}
            {step.ref ? (
              <span className="mt-1 text-xs font-semibold text-fd-primary">
                {step.ref}
              </span>
            ) : null}
          </div>
          {i < steps.length - 1 ? (
            <span
              aria-hidden
              className="flex items-center text-fd-muted-foreground"
            >
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                <path
                  d="M5 12h14m0 0-5-5m5 5-5 5"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </span>
          ) : null}
        </div>
      ))}
    </div>
  );
}

type CompareColumn = {
  title: string;
  items: ReactNode[];
  tone?: 'keep' | 'change';
};

function ComparePanel({ title, items, tone = 'keep' }: CompareColumn) {
  const accent =
    tone === 'keep'
      ? 'text-emerald-600 dark:text-emerald-400'
      : 'text-fd-primary';
  const bar =
    tone === 'keep'
      ? 'bg-emerald-500/70'
      : 'bg-fd-primary/70';
  return (
    <div className="rounded-xl border border-fd-border bg-fd-card p-4">
      <div className="mb-3 flex items-center gap-2">
        <span className={`h-4 w-1 rounded-full ${bar}`} aria-hidden />
        <span
          className={`text-xs font-semibold uppercase tracking-wide ${accent}`}
        >
          {title}
        </span>
      </div>
      <ul className="flex flex-col gap-2">
        {items.map((item, i) => (
          <li
            key={i}
            className="rounded-lg bg-fd-muted/60 px-3 py-2 text-sm text-fd-foreground"
          >
            {item}
          </li>
        ))}
      </ul>
    </div>
  );
}

export function Compare({
  keep,
  change,
}: {
  keep: { title: string; items: ReactNode[] };
  change: { title: string; items: ReactNode[] };
}) {
  return (
    <div className="not-prose my-6 grid grid-cols-1 gap-4 md:grid-cols-2">
      <ComparePanel title={keep.title} items={keep.items} tone="keep" />
      <ComparePanel title={change.title} items={change.items} tone="change" />
    </div>
  );
}
