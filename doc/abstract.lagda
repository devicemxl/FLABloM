% -*- latex -*-
%let submit = True
\documentclass[preprint]{sigplanconf}

%%% Standard definitions from the lhs2TeX installation
%include polycode.fmt

%%% Put your own formatting directives in a separate file
%include paper.format

\usepackage{amsmath}
\usepackage{url}
% \usepackage{ucs}
\usepackage[utf8x]{inputenc}
% \usepackage{unicode-math}
\usepackage{autofe}
\usepackage{latexsym}
\usepackage{stmaryrd}
\usepackage{multicol}
\usepackage{hyperref}
%\usepackage{textgreek}

%%% Some useful macros
%if submit
\newcommand{\todo}[2][?]{}
%else
\newcommand{\todo}[2][?]{\marginpar{\raggedright \tiny TODO: #2}}
%endif

\newcommand{\TODO}[1]{\todo{#1}}
\newcommand{\refSec}[1]{Sec. \ref{#1}}
\newcommand{\refSecs}[1]{Secs. \ref{#1}}
\newcommand{\refSecI}[1]{Section \ref{#1}}
\newcommand{\refSecsI}[1]{Sections \ref{#1}}
\newcommand{\refTab}[1]{Tab. \ref{#1}}

\setcounter{secnumdepth}{0}

\begin{document}

\special{papersize=8.5in,11in}
\setlength{\pdfpageheight}{\paperheight}
\setlength{\pdfpagewidth}{\paperwidth}

\conferenceinfo{TyDe '16}{TODO: Month d--d, 20yy, City, ST, Country}
\copyrightyear{2016}
\copyrightdata{978-1-nnnn-nnnn-n/yy/mm} %TODO
\copyrightdoi{nnnnnnn.nnnnnnn} %TODO

\titlebanner{Preprint}        % These are ignored unless
\preprintfooter{In submission to TyDe'16}   % 'preprint' option specified.

\title{FLABloM: Functional linear algebra with block matrices}
\authorinfo{Adam Sandberg Eriksson \and Patrik Jansson}
           {Chalmers University of Technology, Sweden}
           {saadam@@chalmers.se,patrikj@@chalmers.se}

%\titlerunning{Functional linear algebra with block matrices}
%\authorrunning{Adam Sandberg Eriksson \& Patrik Jansson}

\maketitle

%\tableofcontents

% \abstract{%
%   We define a block based matrix representation in Agda and lift
%   various algebraic structures (semi-near-rings, semi-rings and closed
%   semi-rings) to matrices in order to verify algorithms that can be
%   implemented using the closure operation in a semi-ring.}

% \section{Introduction}
% \label{sec:intro}

\category{TODO: CR-number}{subcategory}{third-level}


TODO: back-port some figures from the slides

TODO: uncomment some proof fragment

\noindent
%
In \cite{bernardy2015certified} Bernardy \& Jansson used a recursive block
formulation of matrices to certify Valiant's
\cite{valiant_general_1975} parsing algorithm.
%
Their matrix formulation was restricted to matrices of size
$2^n \times 2^n$ and this work extends the matrix formulation to allow
for all sizes of matrices and applies similar techniques to algorithms
that can be described as transitive closures of semi-rings of matrices
with inspiration from \cite{dolan2013fun} and \cite{lehmann1977}.

We define a hierarchy of ring structures as Agda records.
%
A semi-near-ring for some type |s| needs an equivalence relation |≃s|,
a distinguished element |zers| and operations addition |+s| and
multiplication |*s|.
%
Our semi-near-ring requires that
%
|zers| and |+s| form a commutative monoid (i.e. |+s| commutes and
|zers| is the left and right identity of |+s|),
%
|zers| is the left and right zero of |*s|,
%
|+s| is idempotent (|∀ x → x +s x ≃s x|) and % TODO: is this really
                                % necessary?
%
|*s| distributes over |+s|.


For the semi-ring we extend the semi-near-ring with another
distinguished element |ones| and proofs that |*s| is associative and
that |ones| is the left and right identity of |*s|.

Finally we extend the semi-ring with an operation |closure| that
computes the transitive closure of an element of the semi-ring (|c| is
the closure of |w| if |c ≃s ones +s w *s c| holds), we denote the
closure of $w$ with $w^*$.

We use two examples of semi-rings with transitive closure:
%
(1) the Booleans with disjunction as addition, conjunction as
multiplication and the closure being |true|; and
%
(2) the natural numbers (|ℕ|) extended with an element |∞|, we let
|zers = ∞|, |ones = 0|, |min| plays the role of |+s|, addition of
natural numbers the role of |*s| and the closure is 0.

\paragraph{Matrices}

%include ../Shape.lagda

%include ../Matrix.lagda

\paragraph{Transitive closure}

%include ../LiftCSR.lagda

\paragraph{Conclusions}
We have presented an algebraic structure useful for (block) matrix
computations and implemented and proved correctness of transitive
closure.
%
Compared to \cite{bernardy2015certified} our implementation handles arbitrary
matrix dimensions but is restricted to semi-rings.
%
Future work would be to extend the proof to cover both arbitrary
dimensions and the more general semi-near-ring structure which would
allow parallel parsing as an application.

% TODO: The bibliography should be embedded for final submission.

\bibliographystyle{abbrvnat}
\bibliography{paper}

\end{document}
